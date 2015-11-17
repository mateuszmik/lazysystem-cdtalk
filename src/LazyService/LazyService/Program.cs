using System;
using System.Configuration;
using System.Threading;
using log4net;
using Topshelf;

namespace LazyService
{
    internal class Program
    {
        private static void Main(string[] args)
        {

            var log = LogManager.GetLogger(typeof(LazyWorker));
            var configurationSource = new AppConfigConfigurationSource();

            HostFactory.Run(x =>
            {
                x.Service<LazyWorker>(s =>
                {
                    s.ConstructUsing(name => new LazyWorker(log,configurationSource));
                    s.WhenStarted(tc => tc.Start());
                    s.WhenStopped(tc => tc.Stop());
                });
                x.RunAsLocalSystem();

                log.InfoFormat("Starting {0} [{1}]",configurationSource.ServiceName,configurationSource.ServiceDescription);
                x.SetDescription(configurationSource.ServiceDescription);
                x.SetDisplayName(configurationSource.ServiceName);
                x.SetServiceName(configurationSource.ServiceName);
            });
        }
    }

    internal class AppConfigConfigurationSource : IConfigurationSource
    {
        public AppConfigConfigurationSource()
        {
            ServiceName = ConfigurationManager.AppSettings["ServiceName"];
            ServiceDescription = ConfigurationManager.AppSettings["ServiceDescription"];
        }

        public string ServiceName { get; set; }
        public string ServiceDescription { get; set; }
    }

    public interface IConfigurationSource
    {
        string ServiceName { get; }
        string ServiceDescription { get; set; }
    }

    public class LazyWorker
    {
        private readonly ILog _log;
        private readonly IConfigurationSource _configurationSource;

        public LazyWorker(ILog log, IConfigurationSource configurationSource)
        {
            _log = log;
            _configurationSource = configurationSource;
        }

        private readonly Timer _timer;


        public void Start()
        {
            _log.InfoFormat("Starting {0} [{1}]",_configurationSource.ServiceName,_configurationSource.ServiceDescription);
            var thread=  new Thread(x => Run());
            thread.Start();

        }

        private void Run()
        {
            while (true)
            {
                _log.InfoFormat("Running {0}...", _configurationSource.ServiceName);
                Thread.Sleep(1000);
            }
        }

        public void Stop()
        {
            _log.InfoFormat("Starting {0} [{1}]", _configurationSource.ServiceName, _configurationSource.ServiceDescription);
        }
    }
}
