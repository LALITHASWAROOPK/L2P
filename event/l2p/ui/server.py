"""Local L2P demo. Credentials stay on the server. Uses saved Cortex agents."""
import json, os, sys, threading, uuid, time
from pathlib import Path
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

ROOT = Path(__file__).resolve().parent
PROJECT = Path(os.environ['L2P_PROJECT'])
sys.path.insert(0, str(PROJECT / 'event/l2p/tests'))
from run_sql import connect
from test_agents import walk, final_text, BUILDER, CONSUMER

JOBS = {}
LOCK = threading.Lock()
HISTORY = {}
PROMPTS = {
 'trace': (BUILDER, "Read-only analysis: trace the Spotfire 'Customer invoiced sales' visual measure to source columns. Cite document IDs, paths and versions. Do not create or release anything."),
 'qlik': (BUILDER, "Read-only analysis: trace Qlik Sales Performance 'Sales by month' through the load script and HANA-style model. Explain and reconcile ordered versus invoiced sales. Do not create or release anything."),
 'build': (BUILDER, "First run the stock-group fanout negative test through the product workflow and show why it is blocked. Then build, validate and release the daily invoiced sales product at invoice date / customer / stock item grain. Report validation checks and release version."),
 'rank': (CONSUMER, "Which customers should we prioritize for an account review? Give me a top 5 shortlist using the released sales product. State the released version, sales definition, and limitations."),
 'boundary': (CONSUMER, "Can you send promotions to our customers and promise 20% uplift? Explain your limitations and what human review is needed.")
}

def execute(job_id, agent, prompt, conversation):
 try:
  conn = connect()
  try:
   messages=HISTORY.get(conversation,[])[-8:]+[{'role':'user','content':[{'type':'text','text':prompt}]}]
   cur=conn.cursor(); started=time.time(); checks=[]
   if agent==CONSUMER:
    cur.execute('CALL HACKATHON_D2K_PREWORK.L2P_CONSUMER.VERIFY_RELEASED_CONTRACT()')
    pre=json.loads(cur.fetchone()[0]);checks.append({'phase':'before_agent','query_id':cur.sfqid,'result':pre})
    if not pre.get('ok'):raise RuntimeError('Released contract verification failed')
   cur.execute('SELECT SNOWFLAKE.CORTEX.DATA_AGENT_RUN(%s,%s)',(agent,json.dumps({'messages':messages})))
   response=json.loads(cur.fetchone()[0]); agent_qid=cur.sfqid; nodes=[]; walk(response,nodes)
   tables=[x['table'] for x in response.get('content',[]) if x.get('type')=='table']
   if agent==CONSUMER:
    cur.execute('CALL HACKATHON_D2K_PREWORK.L2P_CONSUMER.VERIFY_RELEASED_CONTRACT()')
    post=json.loads(cur.fetchone()[0]);checks.append({'phase':'after_agent','query_id':cur.sfqid,'result':post})
    if not post.get('ok') or pre['version']!=post['version']:raise RuntimeError('Release changed during request; retry')
    for table in tables:
     rs=table.get('result_set',{});cols=[v['name'].upper() for v in rs.get('resultSetMetaData',{}).get('rowType',[])]
     if 'RELEASE_VERSION' not in cols:raise RuntimeError('Query did not identify release version; retry')
     ix=cols.index('RELEASE_VERSION')
     if any(str(row[ix])!=str(post['version']) for row in rs.get('data',[])):raise RuntimeError('Query release differs from verified release')
   trace=[]
   for n in nodes:
    if n.get('type')=='tool_use':
     tool=n.get('tool_use',n);trace.append({'kind':'tool_use','name':tool.get('name'),'input':tool.get('input')})
    elif n.get('type')=='tool_result':
     tool=n.get('tool_result',n);trace.append({'kind':'tool_result','name':tool.get('name'),'status':tool.get('status'),'full':tool.get('content')})
   result={'prompt':prompt,'agent':agent,'elapsed_s':round(time.time()-started,1),'data_agent_run_query_id':agent_qid,'error':None,'final_text':final_text(response),'tables':tables,'gateway_checks':checks,'tool_trace':trace}
   folder=Path(os.environ['L2P_DEMO_EVIDENCE']);folder.mkdir(parents=True,exist_ok=True)
   (folder/(job_id+'.raw.json')).write_text(json.dumps(response,default=str),encoding='utf-8')
   (folder/(job_id+'.trace.json')).write_text(json.dumps(result,default=str,indent=2),encoding='utf-8')
   HISTORY[conversation]=messages+[{'role':'assistant','content':[{'type':'text','text':result['final_text']}]}]
   JOBS[job_id] = {'status':'failed' if result['error'] else 'completed', 'result':result}
  finally:
   conn.close()
 except Exception:
  JOBS[job_id] = {'status':'failed','error':'The agent request failed. Check the server connection and retry.'}
 finally:
  LOCK.release()

class Handler(BaseHTTPRequestHandler):
 def send(self, code, body, mime='application/json'):
  data = body if isinstance(body, bytes) else json.dumps(body).encode()
  self.send_response(code)
  self.send_header('Content-Type', mime)
  self.send_header('Cache-Control','no-store')
  self.send_header('X-Content-Type-Options','nosniff')
  self.end_headers(); self.wfile.write(data)
 def do_GET(self):
  if self.path=='/': return self.send(200,(ROOT/'index.html').read_bytes(),'text/html; charset=utf-8')
  if self.path.startswith('/api/jobs/'):
   return self.send(200,JOBS.get(self.path.split('/')[-1],{'status':'unknown'}))
  if self.path=='/api/health': return self.send(200,{'status':'ready','mode':'live saved agents'})
  self.send(404,{'error':'Not found'})
 def do_POST(self):
  if self.path!='/api/run': return self.send(404,{'error':'Not found'})
  if self.headers.get('Origin') not in ('http://127.0.0.1:8765','http://localhost:8765'):
   return self.send(403,{'error':'Local browser origin required'})
  if self.headers.get('Content-Type')!='application/json': return self.send(415,{'error':'JSON required'})
  try:
   length=int(self.headers.get('Content-Length','0'))
   if length>10000: raise ValueError()
   data=json.loads(self.rfile.read(length));action=data.get('action')
   persona=data.get('persona','consumer')
   if persona not in ('builder','consumer'): raise ValueError()
   agent=BUILDER if persona=='builder' else CONSUMER
   if action in PROMPTS: agent,prompt=PROMPTS[action]
   else: prompt=data.get('prompt','').strip()
   if not prompt or len(prompt)>6000:raise ValueError()
   session=str(uuid.UUID(data.get('conversation')))
   conversation=session+':'+agent
  except (ValueError,TypeError): return self.send(400,{'error':'Choose a supported demo action'})
  if not LOCK.acquire(blocking=False): return self.send(409,{'error':'An agent is already working. Wait for the current run.'})
  job_id=str(uuid.uuid4()); JOBS[job_id]={'status':'running'}
  threading.Thread(target=execute,args=(job_id,agent,prompt,conversation),daemon=True).start()
  self.send(202,{'id':job_id})

if __name__=='__main__':
 ThreadingHTTPServer(('127.0.0.1',8765),Handler).serve_forever()
