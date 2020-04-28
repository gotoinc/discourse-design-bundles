import { withPluginApi } from "discourse/lib/plugin-api";
import transformPost from "discourse/lib/transform-post";
import { Placeholder } from "discourse/lib/posts-with-placeholders";

function initializeShopAdvertisement(api) {
  api.modifyClass("component:scrolling-post-stream", {
    buildArgs() {
      return this.getProperties(
        "posts",
        "canCreatePost",
        "multiSelect",
        "gaps",
        "selectedQuery",
        "selectedPostsCount",
        "searchService",
        "showReadIndicator",
        "shopAdvertisementHTML"
      );
    }
  })

  const DAY = 1000 * 60 * 60 * 24;

  api.reopenWidget('post-stream', {
    html(attrs) {
      const posts = attrs.posts || [];
      const postArray = posts.toArray();

      const result = [];

      const before = attrs.gaps && attrs.gaps.before ? attrs.gaps.before : {};
      const after = attrs.gaps && attrs.gaps.after ? attrs.gaps.after : {};

      let prevPost;
      let prevDate;

      const mobileView = this.site.mobileView;

      const shopAdvertisementHTML = attrs.shopAdvertisementHTML

      for (let i = 0; i < postArray.length; i++) {
        const post = postArray[i];

        if (post instanceof Placeholder) {
          result.push(this.attach("post-placeholder"));
          continue;
        }

        const nextPost = i < postArray.length - 1 ? postArray[i + 1] : null;

        const transformed = transformPost(
          this.currentUser,
          this.site,
          post,
          prevPost,
          nextPost
        );
        transformed.canCreatePost = attrs.canCreatePost;
        transformed.mobileView = mobileView;

        if (transformed.canManage) {
          transformed.multiSelect = attrs.multiSelect;

          if (attrs.multiSelect) {
            transformed.selected = attrs.selectedQuery(post);
          }
        }

        if (attrs.searchService) {
          transformed.highlightTerm = attrs.searchService.highlightTerm;
        }

        // Post gap - before
        const beforeGap = before[post.id];
        if (beforeGap) {
          result.push(
            this.attach(
              "post-gap",
              { pos: "before", postId: post.id, gap: beforeGap },
              { model: post }
            )
          );
        }

        // Handle time gaps
        const curTime = new Date(transformed.created_at).getTime();
        if (prevDate) {
          const daysSince = Math.floor((curTime - prevDate) / DAY);
          if (daysSince > this.siteSettings.show_time_gap_days) {
            result.push(this.attach("time-gap", { daysSince }));
          }
        }
        prevDate = curTime;

        //FIXME We don't have access to _heights, _cloaked and postTransformCallbacks
        // because they are defined in global scope
        // of the file discourse/app/widgets/post-stream
        // transformed.height = _heights[post.id];
        // transformed.cloaked = _cloaked[post.id];
        //
        // postTransformCallbacks(transformed);

        if (transformed.isSmallAction) {
          result.push(
            this.attach("post-small-action", transformed, { model: post })
          );
        } else {
          transformed.showReadIndicator = attrs.showReadIndicator;
          result.push(this.attach("post", transformed, { model: post }));
        }

        // Post gap - after
        const afterGap = after[post.id];
        if (afterGap) {
          result.push(
            this.attach(
              "post-gap",
              { pos: "after", postId: post.id, gap: afterGap },
              { model: post }
            )
          );
        }

        prevPost = post;

        if (i == 0) {
          result.push(
            this.attach(
              "advertisement-post",
              { shopAdvertisementHTML: shopAdvertisementHTML }
            )
          );
        }
      }
      return result;
    }
  });
  // https://github.com/discourse/discourse/blob/master/app/assets/javascripts/discourse/lib/plugin-api.js.es6
}

export default {
  name: "shop-advertisement",

  initialize() {
    withPluginApi("0.8.31", initializeShopAdvertisement);
  }
};
