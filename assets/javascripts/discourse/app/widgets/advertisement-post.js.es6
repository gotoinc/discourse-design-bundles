import { createWidget, applyDecorators } from "discourse/widgets/widget";
import RawHtml from "discourse/widgets/raw-html";

export default createWidget("advertisement-post", {
  html(attrs) {
    const html = attrs.shopAdvertisementHTML

    return new RawHtml({ html: html });
  },
});
