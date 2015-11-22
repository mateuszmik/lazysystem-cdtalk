namespace LazyService
{
    public interface IConfigurationSource
    {
        string ServiceName { get; }
        string ServiceDedscription { get; set; }
    }
}