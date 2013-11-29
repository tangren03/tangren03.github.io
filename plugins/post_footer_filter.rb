require './plugins/post_filters'

module AppendFooterFilter
    def append(post)
        author = post.site.config['author']
        url = post.site.config['url']
        pre = post.site.config['original_url_pre']
        post.content + %Q[<p class='post-footer'>
        #{pre or "original link:"}
        <a href='#{post.full_url}'>#{post.full_url}</a>
        <br/>
        {% include post/license.html %}
        </p>]
    end
end

module Jekyll
    class AppendFooter < PostFilter
        include AppendFooterFilter
        def pre_render(post)
            post.content = append(post) if post.is_post?
        end
    end
end

Liquid::Template.register_filter AppendFooterFilter