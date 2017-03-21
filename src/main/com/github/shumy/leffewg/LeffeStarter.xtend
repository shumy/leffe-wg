package com.github.shumy.leffewg

import com.github.shumy.leffewg.plugin.IRouterPlugin
import com.github.shumy.leffewg.plugin.RouteProvider
import io.vertx.core.Vertx
import java.util.List
import java.util.concurrent.CopyOnWriteArrayList
import org.osgi.framework.BundleContext
import org.osgi.service.component.annotations.Activate
import org.osgi.service.component.annotations.Component
import org.osgi.service.component.annotations.Deactivate
import org.osgi.service.component.annotations.Reference

@Component
class LeffeStarter {
  var Vertx vertx
  
  @Reference(policy=DYNAMIC, bind="bind", unbind="unbind")
  val List<IRouterPlugin> plugins = new CopyOnWriteArrayList<IRouterPlugin>
  val RouteProvider provider = new RouteProvider(plugins, Vertx.vertx).init
  
  def void bind(IRouterPlugin plugin) { provider.bind(plugin) }
  def void unbind(IRouterPlugin plugin) { provider.unbind(plugin.name) }
  
  @Activate
  def void start(BundleContext bc) {
    this.vertx = Vertx.vertx
    System.setProperty("vertx.disableDnsResolver", "true")
    
    //register Vertx as a service... 
    bc.registerService(Vertx, this.vertx, null)
    
    //TODO: deploy X verticles per CPU core?
    vertx.deployVerticle(new LeffeVerticle(provider))
  }

  @Deactivate
  def void stop() {
    vertx.close
  }
}