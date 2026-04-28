import { graphql } from "../../generated";

export const PendingTriageItemsQuery = graphql(`
  query PendingTriageItems(
    $limit: Int
    $offset: Int
    $filterByType: TriageItemTypeFilter
    $filterBySurface: String
  ) {
    pendingTriageItems(
      limit: $limit
      offset: $offset
      filterByType: $filterByType
      filterBySurface: $filterBySurface
    ) {
      items {
        __typename
        id
        sourceTable
        sourceId
        surface
        pendingSince
        updatedAt
        provenanceTier
        suggestedDecision
        historicalDecisions {
          id
          decision
          decidedAt
          historianId
        }
        ... on SeedMappingTriage {
          confidence
          mappingMethod
          targetPerson {
            id
            slug
            name {
              zhHans
            }
            dynasty
          }
          dictionaryEntry {
            id
            externalId
            primaryName
            source {
              sourceName
            }
          }
        }
        ... on GuardBlockedMergeTriage {
          proposedRule
          guardType
          personA {
            id
            slug
            name {
              zhHans
            }
            dynasty
          }
          personB {
            id
            slug
            name {
              zhHans
            }
            dynasty
          }
        }
      }
      totalCount
      hasMore
    }
  }
`);
