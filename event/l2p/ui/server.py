"""Local L2P demo. Credentials stay on the server. Uses saved Cortex agents."""
import json, os, sys, threading, uuid
from pathlib import Path
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

ROOT = Path(__file__).resolve().parent
PROJECT = Path(os.environ['L2P_PROJECT'])
sys.path.insert(0, str(PROJECT / 'event/l2p/tests'))
from run_sql import connect
from test_agents import run, BUILDER, CONSUMER

JOBS = {}
LOCK = threading.Lock()
PROMPTS = {
 'trace': (BUILDER, "Read-only analysis: trace the Spotfire 'Customer invoiced sales' visual measure to source columns. Cite document IDs, paths and versions. Do not create or release anything."),
 'qlik': (BUILDER, "Read-only analysis: trace Qlik Sales Performance 'Sales by month' through the load script and HANA-style model. Explain and reconcile ordered versus invoiced sales. Do not create or release anything."),
 'build': (BUILDER, "First run the stock-group fanout negative test through the product workflow and show why it is blocked. Then build, validate and release the daily invoiced sales product at invoice date / customer / stock item grain. Report validation checks and release version."),
 'rank': (CONSUMER, "Which customers should we prioritize for an account review? Give me a top 5 shortlist using the released sales product. State the released version, sales definition, and limitations."),
 'boundary': (CONSUMER, "Can you send promotions to our customers and promise 20% uplift? Explain your limitations and what human review is needed.")
}

def execute(job_id, action):
 try:
  conn = connect()
  try:
   result = run(conn.cursor(), job_id, *PROMPTS[action], out_dir=Path(os.environ['L2P_DEMO_EVIDENCE']))
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
   if length>4096: raise ValueError()
   action=json.loads(self.rfile.read(length)).get('action')
   if action not in PROMPTS: raise ValueError()
  except (ValueError,TypeError): return self.send(400,{'error':'Choose a supported demo action'})
  if not LOCK.acquire(blocking=False): return self.send(409,{'error':'An agent is already working. Wait for the current run.'})
  job_id=str(uuid.uuid4()); JOBS[job_id]={'status':'running'}
  threading.Thread(target=execute,args=(job_id,action),daemon=True).start()
  self.send(202,{'id':job_id})

if __name__=='__main__':
 ThreadingHTTPServer(('127.0.0.1',8765),Handler).serve_forever()
