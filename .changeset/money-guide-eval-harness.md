---
openbudget_server: test
---

# Add the Money guide eval harness

`openbudget_server/test/money_guide/` gains the golden-file schema, a strict validator over `golden/*.yaml`, and a deterministic grader (tools called, citations resolved, no stripped citations, required facts, forbidden and never-suggest wording, and the refuse, signpost and qualify behaviours). The offline eval replays recorded model turns through the real `AgentService`, prompt, tools and citation resolver over a mock transport, so it runs in CI with no network. A `live_eval`-tagged test asks each golden question three times of the real model, grades each run, and writes a cost and pass-rate report to a gitignored path. `dart_test.yaml` skips the tag unless it is asked for by name. The provider key comes only from the environment (filled by Monosecret), and neither the key nor any message content is logged or written to the report.
