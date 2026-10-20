using Helpdesk.Core;

namespace Helpdesk.Tests;

public class SmokeTests
{
    [Fact]
    public void Core_assembly_is_referenced_by_tests()
    {
        Assert.Equal("Helpdesk.Core", typeof(AssemblyMarker).Assembly.GetName().Name);
    }
}
