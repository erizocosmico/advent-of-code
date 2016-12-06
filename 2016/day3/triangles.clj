(use 'clojure.java.io)
(use 'clojure.string)

(defn to-int [s] 
  (Integer/parseInt s))

(defn is-triangle? [ln]
  (let [sides (map to-int (split (trim ln) #" +"))]
    (every? true? (map-indexed 
                    (fn [idx side]
                      (let [sides (take 3 (drop idx (cycle sides)))]
                        (> (reduce + (take 2 sides)) (last sides))))
                    sides))))

(defn -main []
  (with-open [rdr (reader "./data.txt")]
    (println (count (filter is-triangle? (line-seq rdr))))))
