/* eslint-disable */
import * as types from './graphql';
import type { TypedDocumentNode as DocumentNode } from '@graphql-typed-document-node/core';

/**
 * Map of all GraphQL operations in the project.
 *
 * This map has several performance disadvantages:
 * 1. It is not tree-shakeable, so it will include all operations in the project.
 * 2. It is not minifiable, so the string of a GraphQL query will be multiple times inside the bundle.
 * 3. It does not support dead code elimination, so it will add unused operations.
 *
 * Therefore it is highly recommended to use the babel or swc plugin for production.
 * Learn more about it here: https://the-guild.dev/graphql/codegen/plugins/presets/preset-client#reducing-bundle-size
 */
type Documents = {
    "\n  query FeaturedPerson($slug: String!) {\n    person(slug: $slug) {\n      id\n      slug\n      name {\n        zhHans\n        en\n      }\n      dynasty\n      biography {\n        zhHans\n      }\n    }\n  }\n": typeof types.FeaturedPersonDocument,
    "\n  query Person($slug: String!) {\n    person(slug: $slug) {\n      id\n      slug\n      name {\n        zhHans\n        zhHant\n        en\n      }\n      dynasty\n      realityStatus\n      provenanceTier\n      birthDate {\n        yearMin\n        yearMax\n        precision\n        originalText\n        reignEra\n        reignYear\n      }\n      deathDate {\n        yearMin\n        yearMax\n        precision\n        originalText\n        reignEra\n        reignYear\n      }\n      biography {\n        zhHans\n        en\n      }\n      names {\n        id\n        name\n        namePinyin\n        nameType\n        isPrimary\n        startYear\n        endYear\n      }\n      identityHypotheses {\n        id\n        relationType\n        scholarlySupport\n        acceptedByDefault\n        notes\n      }\n    }\n  }\n": typeof types.PersonDocument,
    "\n  query PersonsSearch($search: String, $limit: Int = 20, $offset: Int = 0) {\n    persons(search: $search, limit: $limit, offset: $offset) {\n      items {\n        id\n        slug\n        name {\n          zhHans\n          en\n        }\n        dynasty\n        realityStatus\n        provenanceTier\n      }\n      total\n      hasMore\n    }\n  }\n": typeof types.PersonsSearchDocument,
};
const documents: Documents = {
    "\n  query FeaturedPerson($slug: String!) {\n    person(slug: $slug) {\n      id\n      slug\n      name {\n        zhHans\n        en\n      }\n      dynasty\n      biography {\n        zhHans\n      }\n    }\n  }\n": types.FeaturedPersonDocument,
    "\n  query Person($slug: String!) {\n    person(slug: $slug) {\n      id\n      slug\n      name {\n        zhHans\n        zhHant\n        en\n      }\n      dynasty\n      realityStatus\n      provenanceTier\n      birthDate {\n        yearMin\n        yearMax\n        precision\n        originalText\n        reignEra\n        reignYear\n      }\n      deathDate {\n        yearMin\n        yearMax\n        precision\n        originalText\n        reignEra\n        reignYear\n      }\n      biography {\n        zhHans\n        en\n      }\n      names {\n        id\n        name\n        namePinyin\n        nameType\n        isPrimary\n        startYear\n        endYear\n      }\n      identityHypotheses {\n        id\n        relationType\n        scholarlySupport\n        acceptedByDefault\n        notes\n      }\n    }\n  }\n": types.PersonDocument,
    "\n  query PersonsSearch($search: String, $limit: Int = 20, $offset: Int = 0) {\n    persons(search: $search, limit: $limit, offset: $offset) {\n      items {\n        id\n        slug\n        name {\n          zhHans\n          en\n        }\n        dynasty\n        realityStatus\n        provenanceTier\n      }\n      total\n      hasMore\n    }\n  }\n": types.PersonsSearchDocument,
};

/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 *
 *
 * @example
 * ```ts
 * const query = graphql(`query GetUser($id: ID!) { user(id: $id) { name } }`);
 * ```
 *
 * The query argument is unknown!
 * Please regenerate the types.
 */
export function graphql(source: string): unknown;

/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n  query FeaturedPerson($slug: String!) {\n    person(slug: $slug) {\n      id\n      slug\n      name {\n        zhHans\n        en\n      }\n      dynasty\n      biography {\n        zhHans\n      }\n    }\n  }\n"): (typeof documents)["\n  query FeaturedPerson($slug: String!) {\n    person(slug: $slug) {\n      id\n      slug\n      name {\n        zhHans\n        en\n      }\n      dynasty\n      biography {\n        zhHans\n      }\n    }\n  }\n"];
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n  query Person($slug: String!) {\n    person(slug: $slug) {\n      id\n      slug\n      name {\n        zhHans\n        zhHant\n        en\n      }\n      dynasty\n      realityStatus\n      provenanceTier\n      birthDate {\n        yearMin\n        yearMax\n        precision\n        originalText\n        reignEra\n        reignYear\n      }\n      deathDate {\n        yearMin\n        yearMax\n        precision\n        originalText\n        reignEra\n        reignYear\n      }\n      biography {\n        zhHans\n        en\n      }\n      names {\n        id\n        name\n        namePinyin\n        nameType\n        isPrimary\n        startYear\n        endYear\n      }\n      identityHypotheses {\n        id\n        relationType\n        scholarlySupport\n        acceptedByDefault\n        notes\n      }\n    }\n  }\n"): (typeof documents)["\n  query Person($slug: String!) {\n    person(slug: $slug) {\n      id\n      slug\n      name {\n        zhHans\n        zhHant\n        en\n      }\n      dynasty\n      realityStatus\n      provenanceTier\n      birthDate {\n        yearMin\n        yearMax\n        precision\n        originalText\n        reignEra\n        reignYear\n      }\n      deathDate {\n        yearMin\n        yearMax\n        precision\n        originalText\n        reignEra\n        reignYear\n      }\n      biography {\n        zhHans\n        en\n      }\n      names {\n        id\n        name\n        namePinyin\n        nameType\n        isPrimary\n        startYear\n        endYear\n      }\n      identityHypotheses {\n        id\n        relationType\n        scholarlySupport\n        acceptedByDefault\n        notes\n      }\n    }\n  }\n"];
/**
 * The graphql function is used to parse GraphQL queries into a document that can be used by GraphQL clients.
 */
export function graphql(source: "\n  query PersonsSearch($search: String, $limit: Int = 20, $offset: Int = 0) {\n    persons(search: $search, limit: $limit, offset: $offset) {\n      items {\n        id\n        slug\n        name {\n          zhHans\n          en\n        }\n        dynasty\n        realityStatus\n        provenanceTier\n      }\n      total\n      hasMore\n    }\n  }\n"): (typeof documents)["\n  query PersonsSearch($search: String, $limit: Int = 20, $offset: Int = 0) {\n    persons(search: $search, limit: $limit, offset: $offset) {\n      items {\n        id\n        slug\n        name {\n          zhHans\n          en\n        }\n        dynasty\n        realityStatus\n        provenanceTier\n      }\n      total\n      hasMore\n    }\n  }\n"];

export function graphql(source: string) {
  return (documents as any)[source] ?? {};
}

export type DocumentType<TDocumentNode extends DocumentNode<any, any>> = TDocumentNode extends DocumentNode<  infer TType,  any>  ? TType  : never;
