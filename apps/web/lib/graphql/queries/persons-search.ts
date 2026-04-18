import { graphql } from "../generated";

export const PersonsSearchQuery = graphql(`
  query PersonsSearch($search: String, $limit: Int = 20, $offset: Int = 0) {
    persons(search: $search, limit: $limit, offset: $offset) {
      items {
        id
        slug
        name {
          zhHans
          en
        }
        dynasty
        realityStatus
        provenanceTier
      }
      total
      hasMore
    }
  }
`);
