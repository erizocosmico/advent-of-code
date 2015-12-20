(use 'clojure.java.io)
(use 'clojure.set)

(defn coords-for-step
  [x y step]
  (case step
    \< [(dec x) y]
    \> [(inc x) y]
    \^ [x (inc y)]
    \v [x (dec y)]))

(defn houses-with-presents
  [input]
  (loop [house-coords (conj (set nil) [0 0]) x 0 y 0 in input]
    (if (= (count in) 0)
      house-coords
      (let [c (first in)
            coords (coords-for-step x y c)]
        (recur (conj house-coords coords)
               (nth coords 0)
               (nth coords 1)
               (rest in))))))

(defn split-steps
  [input]
  (loop [i 0 a [] b [] in input]
    (if (= (count in) 0)
      [a b]
      (let [c (first in)]
        (if (even? i)
          (recur (inc i) (conj a c) b (rest in))
          (recur (inc i) a (conj b c) (rest in)))))))

(defn -main []
  (with-open [rdr (reader "./data.txt")]
    (doseq [input (line-seq rdr)]
      (println (count (apply union (map houses-with-presents (split-steps input))))))))


