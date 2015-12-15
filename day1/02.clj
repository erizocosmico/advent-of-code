(use 'clojure.java.io)

(defn dir-for-char [c] 
  (case c \( 1 \) -1))

(defn first-char-basement [line]
  (loop [i 1 floor 0 ln line]
    (let [new-floor (+ (dir-for-char (first ln)) floor)]
      (cond (< new-floor 0) i
            :else (recur (inc i) new-floor (rest ln))))))

(defn -main []
  (with-open [rdr (reader "./data.txt")]
    (doseq [line (line-seq rdr)]
      (println (first-char-basement line)))))
