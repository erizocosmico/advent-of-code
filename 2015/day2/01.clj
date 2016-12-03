(use 'clojure.java.io)
(require '[clojure.string :refer [split]])

(defn calc-needed-paper [[l w h]]
  (let [sides [(* l w) (* l h) (* w h)]]
    (apply + (conj (map #(* % 2) sides) (apply min sides)))))

(defn process-line [line]
  (map read-string (split line #"x")))

(defn -main []
  (with-open [rdr (reader "./data.txt")]
    (println (apply + 
           (map #(calc-needed-paper (process-line %)) 
                (line-seq rdr))))))
