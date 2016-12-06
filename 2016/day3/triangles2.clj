(use 'clojure.java.io)
(use 'clojure.string)

(defn to-int [s] 
  (Integer/parseInt s))

(defn line-to-nums [ln]
  (map to-int (split (trim ln) #" +")))

(defn is-triangle? [sides]
  (every? true? (map-indexed 
                  (fn [idx side]
                    (let [sides (take 3 (drop idx (cycle sides)))]
                      (> (reduce + (take 2 sides)) (last sides))))
                  sides)))

(defn rotate [lines]
  (map (fn [idx]
         (map (fn [ln] (first (drop idx ln))) lines)) (range (count lines))))

(defn -main []
  (with-open [rdr (reader "./data.txt")]
    (println (loop [idx 0
                    lines (map line-to-nums (line-seq rdr))
                    possible 0]
              (let [rotated-lines (rotate (take 3 lines))]
                (if (= (count lines) 0)
                  possible
                  (recur (+ idx 3)
                         (drop 3 lines)
                         (+ possible (count (filter is-triangle? rotated-lines))))))))))
