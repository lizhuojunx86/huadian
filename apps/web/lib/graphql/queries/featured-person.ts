import { graphql } from "../generated";

export const FeaturedPersonQuery = graphql(`
  query FeaturedPerson($slug: String!) {
    person(slug: $slug) {
      id
      slug
      name {
        zhHans
        en
      }
      dynasty
      biography {
        zhHans
      }
    }
  }
`);
