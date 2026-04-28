import { graphql } from "../../generated";

export const RecordTriageDecisionMutation = graphql(`
  mutation RecordTriageDecision($input: RecordTriageDecisionInput!) {
    recordTriageDecision(input: $input) {
      triageDecision {
        id
        sourceTable
        sourceId
        decision
        decidedAt
        historianId
      }
      nextPendingItemId
      error {
        code
        message
      }
    }
  }
`);
