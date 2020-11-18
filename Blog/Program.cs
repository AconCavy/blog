using System.Threading.Tasks;
using Blog.Extensions;
using Markdig.Extensions.Bootstrap;
using Statiq.App;
using Statiq.Common;
using Statiq.Markdown;
using Statiq.Web;

namespace Blog
{
    public static class Program
    {
        public static async Task<int> Main(string[] args) =>
            await Bootstrapper.Factory
                .CreateWeb(args)
                .ConfigureTemplates(templates =>
                {
                    var markdownModule = new RenderMarkdown()
                        .UseExtensions()
                        .UseExtension<BootstrapExtension>()
                        .UseExtension<MarkdownExtension>();
                    if (templates.ContainsKey(MediaTypes.Markdown))
                        templates[MediaTypes.Markdown].Module = markdownModule;
                    else
                        templates.Add(MediaTypes.Markdown,
                            new Template(ContentType.Content, Phase.Process, markdownModule));
                })
                .RunAsync();
    }
}