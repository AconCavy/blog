using Markdig;
using Markdig.Extensions.Tables;
using Markdig.Renderers;

namespace Blog.Extensions
{
    public class ResponsiveTableExtension : IMarkdownExtension
    {
        public void Setup(MarkdownPipelineBuilder pipeline)
        {
        }

        public void Setup(MarkdownPipeline pipeline, IMarkdownRenderer renderer)
        {
            if (renderer is HtmlRenderer htmlRenderer)
                htmlRenderer.ObjectRenderers.ReplaceOrAdd<HtmlTableRenderer>(new ResponsiveTableRenderer());
        }
    }
}