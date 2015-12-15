(use 'clojure.java.io)

(defn calc-floor [line] 
  (apply + (map #(case % \( 1 \) -1) line)))

(defn -main []
  (with-open [rdr (reader "./data.txt")]
    (doseq [line (line-seq rdr)]
      (println (calc-floor line)))))
