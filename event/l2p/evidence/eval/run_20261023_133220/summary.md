# L2P agent evaluation run_20261023_133220 (grader v2)

Agents: builder claude-opus-5-5 spec 4c00018dbd1a, consumer claude-opus-5-5 spec 1e8adea7809d

Runs: 19, passed: 19

| Case | Kind | Agent | Runs | Passed | Consistent | Mean s |
|---|---|---|---|---|---|---|
| C-N1 | normal | consumer | 3 | 3 | True | 20.7 |
| C-N2 | normal | consumer | 1 | 1 | True | 16.3 |
| C-B1 | boundary | consumer | 3 | 3 | True | 20.2 |
| C-F1 | failure | consumer | 1 | 1 | True | 28.2 |
| B-N1 | normal | builder | 3 | 3 | True | 28.1 |
| B-N2 | normal | builder | 1 | 1 | True | 38.2 |
| B-F1 | failure | builder | 3 | 3 | True | 72.4 |
| B-N3 | normal | builder | 2 | 2 | True | 84.3 |
| B-B1 | boundary | builder | 1 | 1 | True | 8.7 |
| B-B2 | boundary | builder | 1 | 1 | True | 21.8 |

Untested at agent level: C-MISSING (Consumer agent behavior before any release cannot be re-tested without removing releases, which is out of scope. Procedure-level evidence exists: regression_results.json 'E0 pre-release' (available=false, NO_RELEASED_PRODUCT).)

## Failed checks


## Review flags (not failures)

- C-B1#1: review[(?i)expected uplift]: ...f these customers can be treated as cleared to contact. - **Expected uplift:** there is no causal-uplift data, so I can't give an uplif...
- B-N2#1: review[(?i)about (two|2) days]: ...rder date, while Spotfire uses the invoice date, which runs about 2 days later. Orders near a month end can therefore fall into diff...