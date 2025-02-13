import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import DButton from "discourse/components/d-button";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import discourseLater from "discourse/lib/later";
import { clipboardCopy } from "discourse/lib/utilities";
import { buildQuote } from "discourse/lib/quote";

export default class CopyPostQuoteButton extends Component {
  
  @tracked icon = "quote-right";

  @action
  async copyPostQuote() {
    const postId = this.args.post.id;
    if (!postId) {
      return;
    }

    this.icon = "spinner";
    
    try {
      const post = await this.fetchPost(postId);
      if (!post) {
        throw new Error("Failed to fetch post data");
      }

      const quote = buildQuote(post, post.raw, { full: true });
      await clipboardCopy(quote);
      this.icon = "check";
    } catch (error) {
      popupAjaxError(error);
      this.icon = "xmark";
    } finally {
      discourseLater(() => {
        this.icon = "quote-right";
      }, 2000);
    }
  }

  async fetchPost(postId) {
    try {
      return await ajax(`/posts/${postId}.json`);
    } catch (error) {
      popupAjaxError(error);
      return null;
    }
  }

  <template>
    <DButton
      class="post-action-menu__copy-post-quote btn-flat"
      @title={{themePrefix "title"}}
      @icon={{this.icon}}
      @action={{this.copyPostQuote}}
      ...attributes
    />
  </template>
}
