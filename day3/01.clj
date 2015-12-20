(use 'clojure.java.io)

(defn coords-for-step
  [x y step]
  (case step
    \< [(dec x) y]
    \> [(inc x) y]
    \^ [x (inc y)]
    \v [x (dec y)]))

(defn houses-with-presents
  [input]
  (loop [house-coords (set nil) x 0 y 0 in input]
    (if (= (count in) 0)
      (count house-coords)
      (let [c (first in)
            coords (coords-for-step x y c)]
        (recur (conj house-coords coords)
               (nth coords 0)
               (nth coords 1)
               (rest in))))))

(defn -main []
  (with-open [rdr (reader "./data.txt")]
    (doseq [input (line-seq rdr)]
      (println (houses-with-presents input)))))

