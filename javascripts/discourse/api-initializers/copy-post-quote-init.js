import { apiInitializer } from "discourse/lib/api";
import CopyPostQuoteButton from "../components/copy-post-quote-button";

export default apiInitializer("2.0.0", (api) => {
  const currentUser = api.getCurrentUser();

  if (!currentUser) {
    return;
  }

  api.registerValueTransformer("post-menu-buttons", ({ value: dag }) => {
    dag.add("copy-post-quote", CopyPostQuoteButton);
  });
});
