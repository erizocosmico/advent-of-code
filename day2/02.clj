(use 'clojure.java.io)
(require '[clojure.string :refer [split]])

(defn calc-needed-ribbon [[l w h]]
  (let [sides [[l w] [l h] [w h]]
        perimeters (map #(* 2 (apply + %)) sides)]
    (+ (apply min perimeters) (* l w h))))

(defn process-line [line]
  (map read-string (split line #"x")))

(defn -main []
  (with-open [rdr (reader "./data.txt")]
    (println (apply + 
           (map #(calc-needed-ribbon (process-line %)) 
                (line-seq rdr))))))

