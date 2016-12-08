(use 'clojure.java.io)
(use 'clojure.string)

(defn to-int [s] 
  (Integer/parseInt s))

(defn room [letters sector checksum]
  {:letters letters :sector-id (to-int sector) :checksum checksum})

(defn to-room [ln]
  (let [parts (split (trim ln) #"-")
        [sector checksum] (drop 1 (re-find #"(\d+)\[([a-z]+)]" (last parts)))]
    (room (apply str (drop-last parts)) sector checksum)))

(defn compare-by-freq-and-alpha [[freq1 letter1] [freq2 letter2]]
  (or (> freq1 freq2)
      (and (= freq1 freq2)
           (< (compare letter1 letter2) 0))))

(defn sort-by-freq-and-alpha [freqs]
  (sort-by (fn [k] [(val k) (key k)]) compare-by-freq-and-alpha freqs))

(defn letter-freqs [letters]
  (loop [remaining letters
         freqs {}]
    (if (= (count remaining) 0)
      (sort-by-freq-and-alpha freqs)
      (let [letter (first remaining)]
        (recur (drop 1 remaining)
               (assoc freqs letter (inc (or (get freqs letter) 0))))))))

(defn is-room? [room]
  (let [freqs (letter-freqs (:letters room))]
    (= (apply str (take 5 (keys freqs)))
       (:checksum room))))

(defn -main []
  (with-open [rdr (reader "./data.txt")]
    (println (reduce + 0 
                     (map #(:sector-id %)
                          (filter is-room?
                                  (map to-room (line-seq rdr))))))))
