import { createSchema, createYoga } from "graphql-yoga";
import { createServer } from "node:http";

const yoga = createYoga({
  schema: createSchema({
    typeDefs: /* GraphQL */ `
      type Query {
        hello: String!
      }
    `,
    resolvers: {
      Query: {
        hello: () => "华典智谱 API — Phase 0 stub",
      },
    },
  }),
});

const server = createServer(yoga);

const port = process.env.PORT ?? 4000;
server.listen(port, () => {
  console.info(`GraphQL API running at http://localhost:${port}/graphql`);
});
