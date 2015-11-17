using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace LazyWebApp.Controllers
{
    public class HomeController : Controller
    {
        private ConfigurationSource _configurationSource;
        //
        // GET: /Home/

        public HomeController()
        {
            _configurationSource = new ConfigurationSource();
        }

        public ActionResult Index()
        {
            ViewBag.Title = _configurationSource.ServiceName;
            return View(ViewBag);
        }

    }

    public class ConfigurationSource
    {
        public ConfigurationSource()
        {
            ServiceName = ConfigurationManager.AppSettings["WebAppName"];
        }

        public string ServiceName { get; set; }
    }
}
