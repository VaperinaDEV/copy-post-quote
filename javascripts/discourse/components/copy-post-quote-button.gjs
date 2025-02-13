import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import DButton from "discourse/components/d-button";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import discourseLater from "discourse/lib/later";
import { clipboardCopy } from "discourse/lib/utilities";
import { buildQuote } from "discourse/lib/quote";
import { i18n } from "discourse-i18n";

export default class CopyPostQuoteButton extends Component { 
  @tracked icon = "quote-right";
  @tracked quoteText = "";
  @tracked showCopyTooltip = false;

  @action
  async prepareQuote() {
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

      this.quoteText = buildQuote(post, post.raw, { full: true });
      this.icon = "clipboard";
      
      // Show the copy tooltip/message
      this.showCopyTooltip = true;
      discourseLater(() => {
        this.showCopyTooltip = false;
      }, 3000); // Hide after 3 seconds
    } catch (error) {
      popupAjaxError(error);
      this.icon = "xmark";
    }
  }

  @action
  async copyQuote() {
    if (!this.quoteText) {
      return;
    }

    try {
      await clipboardCopy(this.quoteText);
      this.icon = "check";
    } catch (error) {
      popupAjaxError(error);
      this.icon = "xmark";
    } finally {
      discourseLater(() => {
        this.icon = "quote-right";
        this.quoteText = "";
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
    {{#if this.quoteText}}
      <div class="copy-post-quote-button">
        {{#if this.showCopyTooltip}}
          <span class="copy-tooltip">{{i18n (themePrefix "tooltip_title")}}</span>
        {{/if}}
        <DButton
          class="post-action-menu__copy-quote --copy btn-flat"
          @title={{themePrefix "copy_quote_title"}}
          @icon={{this.icon}}
          @action={{this.copyQuote}}
          ...attributes
        />
      </div>
    {{else}}
      <DButton
        class="post-action-menu__copy-quote --prepare btn-flat"
        @title={{themePrefix "prepare_quote_title"}}
        @icon={{this.icon}}
        @action={{this.prepareQuote}}
        ...attributes
      />
    {{/if}}
  </template>
}
