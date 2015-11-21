using System.Threading;
using log4net;

namespace LazyService
{
    public class LazyWorker
    {
        private readonly ILog _log;
        private readonly IConfigurationSource _configurationSource;
        private bool shouldStop = false;

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
            while (!shouldStop)
            {
                _log.InfoFormat("Running {0}...", _configurationSource.ServiceName);
                Thread.Sleep(1000);
            }
        }

        public void Stop()
        {
            shouldStop = true;
            _log.InfoFormat("Starting {0} [{1}]", _configurationSource.ServiceName, _configurationSource.ServiceDescription);
        }
    }
}