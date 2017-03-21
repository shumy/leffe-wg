package com.github.shumy.leffewg

import com.github.shumy.leffewg.plugin.IPlugin
import com.github.shumy.leffewg.plugin.PluginProvider
import io.vertx.core.Vertx
import java.util.List
import java.util.concurrent.CopyOnWriteArrayList
import org.osgi.service.component.annotations.Activate
import org.osgi.service.component.annotations.Component
import org.osgi.service.component.annotations.Deactivate
import org.osgi.service.component.annotations.Reference

@Component
class LeffeStarter {
  var Vertx vertx
  
  @Reference(policy=DYNAMIC, bind="bind", unbind="unbind")
  val List<IPlugin> plugins = new CopyOnWriteArrayList<IPlugin>
  val PluginProvider provider = new PluginProvider(plugins, Vertx.vertx).init
  
  def void bind(IPlugin plugin) { provider.bind(plugin) }
  def void unbind(IPlugin plugin) { provider.unbind(plugin.name) }
  
  @Activate
  def void start() {
    this.vertx = Vertx.vertx
    System.setProperty("vertx.disableDnsResolver", "true")
    
    //TODO: deploy X verticles per CPU core?
    vertx.deployVerticle(new LeffeVerticle(provider))
  }

  @Deactivate
  def void stop() {
    vertx.close
  }
}