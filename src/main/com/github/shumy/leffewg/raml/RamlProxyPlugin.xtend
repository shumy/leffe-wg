package com.github.shumy.leffewg.raml

import com.github.shumy.leffewg.plugin.Location
import com.github.shumy.leffewg.plugin.IPlugin
import io.vertx.ext.web.Router
import org.eclipse.xtend.lib.annotations.Accessors
import org.osgi.service.component.annotations.Component
import io.vertx.core.http.HttpMethod

@Component
class RamlProxyPlugin implements IPlugin {
  @Accessors val String name = "raml-proxy"
  
  override config(Location location, Router router) {
    println('raml-proxy-config: ' + location.name)
    
    val api = RamlReader.readConfig(location.config)
    api.resources.forEach[ resource |
      val path = location.uri +  RamlPathTransform.toSimpleRest(resource.resourcePath)
      resource.methods.forEach[ meth |
        val method = HttpMethod.valueOf(meth.method.toUpperCase)
        println('''  «method» «path»''')
        router.route(method, path).handler[
          response.end('''{ "message": "Hello", "path": «path» }''')
        ]
      ]
    ]
  }
}