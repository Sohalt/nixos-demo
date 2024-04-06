(ns hello-server
  (:gen-class)
  (:require
   [clojure.java.shell :refer [sh]]
   [org.httpkit.server :as server]))

(defn greeting [] (:out (sh "hello")))

(defn app [req]
  {:status 200
   :body (greeting)})

(defn -main [port]
  (let [s (server/run-server #'app {:port (parse-long port)
                                    :legacy-return-value? false})]
    (println "Started server on port " (server/server-port s))))
