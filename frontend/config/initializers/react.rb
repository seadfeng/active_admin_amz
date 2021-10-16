Rails.configuration.react.server_renderer =
  Class.new(React::ServerRendering::BundleRenderer) do
    private

    def render_from_parts(before, main, after) 
      js_code = compose_js(before, main, after)
      @context.eval(js_code)
    end

    def compose_js(before, main, after)
      <<-JS
        (function () {
          #{before}
          var data = #{main};
          var result = data['html'];
          #{after}
          return data;
        })()
      JS
    end
  end

Rails.configuration.react.view_helper_implementation =
  Class.new(React::Rails::ComponentMount) do
    def setup(*)
      super.tap { init_component_styles }
    end

    private

    def prerender_component(*)
      data = super

      case data
      when Hash
        register_component_style(data['styles'])
        data['html'].html_safe
      else
        data.html_safe
      end
    end

    def init_component_styles
      @controller.instance_variable_set(:@styled_component_styles, '')
    end

    def register_component_style(style) 
      @controller.instance_variable_get(:@styled_component_styles) << style.to_s 
    end
end