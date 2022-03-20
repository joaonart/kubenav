package io.kubenav.kubenav

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.*
import io.flutter.plugin.common.MethodChannel.*
import java.lang.Exception
import java.util.concurrent.Executors;

import kubenav.Kubenav;

class KubenavPlugin : FlutterPlugin, MethodCallHandler {
  private lateinit var channel : MethodChannel

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    val taskQueue = flutterPluginBinding.binaryMessenger.makeBackgroundTaskQueue()
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "kubenav.io", StandardMethodCodec.INSTANCE, taskQueue)
    channel.setMethodCallHandler(this)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "kubernetesRequest") {
      val clusterServer = call.argument("clusterServer") as String?
      val clusterCertificateAuthorityData = call.argument("clusterCertificateAuthorityData") as String?
      val clusterInsecureSkipTLSVerify = call.argument("clusterInsecureSkipTLSVerify") as Boolean?
      val userClientCertificateData = call.argument("userClientCertificateData") as String?
      val userClientKeyData = call.argument("userClientKeyData") as String?
      val userToken = call.argument("userToken") as String?
      val userUsername = call.argument("userUsername") as String?
      val userPassword = call.argument("userPassword") as String?
      val requestMethod = call.argument("requestMethod") as String?
      val requestURL = call.argument("requestURL") as String?
      val requestBody = call.argument("requestBody") as String?

      if (clusterServer == null || clusterCertificateAuthorityData == null || clusterInsecureSkipTLSVerify == null || userClientCertificateData == null || userClientKeyData == null || userToken == null || userUsername == null || userPassword == null || requestMethod == null || requestURL == null || requestBody == null) {
        result.error("BAD_ARGUMENTS", null, null)
      } else {
        kubernetesRequest(clusterServer, clusterCertificateAuthorityData, clusterInsecureSkipTLSVerify, userClientCertificateData, userClientKeyData, userToken, userUsername, userPassword, requestMethod, requestURL, requestBody, result)
      }
    } else if (call.method == "prettifyYAML") {
      val jsonStr = call.argument("jsonStr") as String?

      if (jsonStr == null) {
        result.error("BAD_ARGUMENTS", null, null)
      } else {
        prettifyYAML(jsonStr, result)
      }
    } else if (call.method == "createJSONPatch") {
      val source = call.argument("source") as String?
      val target = call.argument("target") as String?

      if (source == null || target == null) {
        result.error("BAD_ARGUMENTS", null, null)
      } else {
        createJSONPatch(source, target, result)
      }
    } else if (call.method == "kubernetesGetLogs") {
      val clusterServer = call.argument("clusterServer") as String?
      val clusterCertificateAuthorityData = call.argument("clusterCertificateAuthorityData") as String?
      val clusterInsecureSkipTLSVerify = call.argument("clusterInsecureSkipTLSVerify") as Boolean?
      val userClientCertificateData = call.argument("userClientCertificateData") as String?
      val userClientKeyData = call.argument("userClientKeyData") as String?
      val userToken = call.argument("userToken") as String?
      val userUsername = call.argument("userUsername") as String?
      val userPassword = call.argument("userPassword") as String?
      val names = call.argument("names") as String?
      val namespace = call.argument("namespace") as String?
      val container = call.argument("container") as String?
      val since = call.argument("since") as kotlin.Int?
      val filter = call.argument("filter") as String?
      val previous = call.argument("previous") as Boolean?

      if (clusterServer == null || clusterCertificateAuthorityData == null || clusterInsecureSkipTLSVerify == null || userClientCertificateData == null || userClientKeyData == null || userToken == null || userUsername == null || userPassword == null || names == null || namespace == null || container == null || since == null || filter == null || previous == null) {
        result.error("BAD_ARGUMENTS", null, null)
      } else {
        kubernetesGetLogs(clusterServer, clusterCertificateAuthorityData, clusterInsecureSkipTLSVerify, userClientCertificateData, userClientKeyData, userToken, userUsername, userPassword, names, namespace, container, since, filter, previous, result)
      }
    } else if (call.method == "kubernetesStartServer") {
      kubernetesStartServer(result)
    } else if (call.method == "azureGetClusters") {
      val subscriptionID = call.argument("subscriptionID") as String?
      val tenantID = call.argument("tenantID") as String?
      val clientID = call.argument("clientID") as String?
      val clientSecret = call.argument("clientSecret") as String?
      val isAdmin = call.argument("isAdmin") as Boolean?

      if (subscriptionID == null || tenantID == null || clientID == null || clientSecret == null || isAdmin == null) {
        result.error("BAD_ARGUMENTS", null, null)
      } else {
        azureGetClusters(subscriptionID, tenantID, clientID, clientSecret, isAdmin, result)
      }
    } else if (call.method == "awsGetClusters") {
      val accessKeyID = call.argument("accessKeyID") as String?
      val secretKey = call.argument("secretKey") as String?
      val region = call.argument("region") as String?
      val sessionToken = call.argument("sessionToken") as String?

      if (accessKeyID == null || secretKey == null || region == null || sessionToken == null) {
        result.error("BAD_ARGUMENTS", null, null)
      } else {
        awsGetClusters(accessKeyID, secretKey, region, sessionToken, result)
      }
    } else if (call.method == "awsGetToken") {
      val accessKeyID = call.argument("accessKeyID") as String?
      val secretKey = call.argument("secretKey") as String?
      val region = call.argument("region") as String?
      val sessionToken = call.argument("sessionToken") as String?
      val clusterID = call.argument("clusterID") as String?

      if (accessKeyID == null || secretKey == null || region == null || sessionToken == null || clusterID == null) {
        result.error("BAD_ARGUMENTS", null, null)
      } else {
        awsGetToken(accessKeyID, secretKey, region, sessionToken, clusterID, result)
      }
    } else {
      result.notImplemented()
    }
  }

  private fun kubernetesRequest(clusterServer: String, clusterCertificateAuthorityData: String, clusterInsecureSkipTLSVerify: Boolean, userClientCertificateData: String, userClientKeyData: String, userToken: String, userUsername: String, userPassword: String, requestMethod: String, requestURL: String, requestBody: String, result: MethodChannel.Result) {
    try {
      val data: String = Kubenav.kubernetesRequest(clusterServer, clusterCertificateAuthorityData, clusterInsecureSkipTLSVerify, userClientCertificateData, userClientKeyData, userToken, userUsername, userPassword, requestMethod, requestURL, requestBody)
      result.success(data)
    } catch (e: Exception) {
      result.error("KUBERNETES_REQUEST_FAILED", e.localizedMessage, null)
    }
  }

  private fun prettifyYAML(jsonStr: String, result: MethodChannel.Result) {
    try {
      val data: String = Kubenav.prettifyYAML(jsonStr)
      result.success(data)
    } catch (e: Exception) {
      result.error("PRETTIFY_YAML_FAILED", e.localizedMessage, null)
    }
  }

  private fun createJSONPatch(source: String, target: String, result: MethodChannel.Result) {
    try {
      val data: String = Kubenav.createJSONPatch(source, target)
      result.success(data)
    } catch (e: Exception) {
      result.error("CREATE_JSON_PATCH_FAILED", e.localizedMessage, null)
    }
  }

  private fun kubernetesGetLogs(clusterServer: String, clusterCertificateAuthorityData: String, clusterInsecureSkipTLSVerify: Boolean, userClientCertificateData: String, userClientKeyData: String, userToken: String, userUsername: String, userPassword: String, names: String, namespace: String, container: String, since: kotlin.Int, filter: String, previous: Boolean, result: MethodChannel.Result) {
    try {
      val data: String = Kubenav.kubernetesGetLogs(clusterServer, clusterCertificateAuthorityData, clusterInsecureSkipTLSVerify, userClientCertificateData, userClientKeyData, userToken, userUsername, userPassword, names, namespace, container, since.toLong(), filter, previous)
      result.success(data)
    } catch (e: Exception) {
      result.error("KUBERNETES_GET_LOGS_FAILED", e.localizedMessage, null)
    }
  }

  private fun kubernetesStartServer(result: MethodChannel.Result) {
    val executor = Executors.newSingleThreadExecutor()
    executor.execute {
      Kubenav.kubernetesStartServer();
    }
    result.success("")
  }

  private fun azureGetClusters(subscriptionID: String, tenantID: String, clientID: String, clientSecret: String, isAdmin: Boolean, result: MethodChannel.Result) {
    try {
      val data: String = Kubenav.azureGetClusters(subscriptionID, tenantID, clientID, clientSecret, isAdmin)
      result.success(data)
    } catch (e: Exception) {
      result.error("AZURE_GET_CLUSTERS_FAILED", e.localizedMessage, null)
    }
  }

  private fun awsGetClusters(accessKeyID: String, secretKey: String, region: String, sessionToken: String, result: MethodChannel.Result) {
    try {
      val data: String = Kubenav.awsGetClusters(accessKeyID, secretKey, region, sessionToken)
      result.success(data)
    } catch (e: Exception) {
      result.error("AWS_GET_CLUSTERS_FAILED", e.localizedMessage, null)
    }
  }

  private fun awsGetToken(accessKeyID: String, secretKey: String, region: String, sessionToken: String, clusterID: String, result: MethodChannel.Result) {
    try {
      val data: String = Kubenav.awsGetToken(accessKeyID, secretKey, region, sessionToken, clusterID)
      result.success(data)
    } catch (e: Exception) {
      result.error("AWS_GET_TOKEN_FAILED", e.localizedMessage, null)
    }
  }
}
