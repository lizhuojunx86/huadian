import { graphql } from "../generated";

export const PersonQuery = graphql(`
  query Person($slug: String!) {
    person(slug: $slug) {
      id
      slug
      name {
        zhHans
        zhHant
        en
      }
      dynasty
      realityStatus
      provenanceTier
      birthDate {
        yearMin
        yearMax
        precision
        originalText
        reignEra
        reignYear
      }
      deathDate {
        yearMin
        yearMax
        precision
        originalText
        reignEra
        reignYear
      }
      biography {
        zhHans
        en
      }
      names {
        id
        name
        namePinyin
        nameType
        isPrimary
        startYear
        endYear
      }
      identityHypotheses {
        id
        relationType
        scholarlySupport
        acceptedByDefault
        notes
      }
    }
  }
`);
