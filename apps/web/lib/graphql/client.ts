import { GraphQLClient } from "graphql-request";

const API_URL =
  process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:4000/graphql";
// P1 deployment note: split into INTERNAL_API_URL (server-side, container
// internal) and NEXT_PUBLIC_API_URL (client-side, public endpoint). Server
// Components should use INTERNAL_API_URL; client hydration uses public.

export const graphqlClient = new GraphQLClient(API_URL);
