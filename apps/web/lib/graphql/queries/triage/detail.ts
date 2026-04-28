import { graphql } from "../../generated";

export const TriageItemQuery = graphql(`
  query TriageItem($id: ID!) {
    triageItem(id: $id) {
      __typename
      id
      sourceTable
      sourceId
      surface
      pendingSince
      updatedAt
      provenanceTier
      sourceEvidenceId
      suggestedDecision
      historicalDecisions {
        id
        decision
        decidedAt
        historianId
        historianCommitRef
        architectAckRef
        reasonText
        reasonSourceType
      }
      ... on SeedMappingTriage {
        confidence
        mappingMethod
        mappingMetadata
        targetPerson {
          id
          slug
          name {
            zhHans
            en
          }
          dynasty
          realityStatus
          biography {
            zhHans
          }
        }
        dictionaryEntry {
          id
          externalId
          entryType
          primaryName
          aliases
          attributes
          source {
            sourceName
            sourceVersion
            license
          }
        }
      }
      ... on GuardBlockedMergeTriage {
        proposedRule
        guardType
        guardPayload
        evidence
        personA {
          id
          slug
          name {
            zhHans
            en
          }
          dynasty
          realityStatus
          biography {
            zhHans
          }
        }
        personB {
          id
          slug
          name {
            zhHans
            en
          }
          dynasty
          realityStatus
          biography {
            zhHans
          }
        }
      }
    }
  }
`);

export const TriageDecisionsForSurfaceQuery = graphql(`
  query TriageDecisionsForSurface($surface: String!, $limit: Int) {
    triageDecisionsForSurface(surface: $surface, limit: $limit) {
      id
      sourceTable
      sourceId
      surfaceSnapshot
      decision
      reasonText
      reasonSourceType
      historianId
      historianCommitRef
      architectAckRef
      decidedAt
      downstreamApplied
    }
  }
`);
