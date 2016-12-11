(use 'clojure.java.io)
(use 'clojure.string)

(defn most-frequent [coll]
  (first (first (sort-by val (frequencies coll)))))

(defn -main []
  (with-open [rdr (reader "./data.txt")]
    (let [lines (map trim (line-seq rdr))]
      (println (apply str 
                      (map-indexed (fn [idx _]
                                     (most-frequent (map #(first (drop idx %)) lines))) 
                                   (first lines)))))))
