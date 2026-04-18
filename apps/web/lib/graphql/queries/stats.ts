import { graphql } from "../generated";

export const StatsQuery = graphql(`
  query Stats {
    stats {
      personsCount
      namesCount
      booksCount
    }
  }
`);
