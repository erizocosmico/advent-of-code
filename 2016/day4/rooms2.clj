(use 'clojure.java.io)
(use 'clojure.string)

(defn to-int [s] 
  (Integer/parseInt s))

(defn to-room [ln]
  {:name (subs ln 0 (last-index-of ln "-")) 
   :sector-id (to-int (second (re-find #"(\d+)" ln)))})

(def alpha-start (byte \a))
(def alpha-end (byte \z))
(def alpha-mod (inc (- alpha-end alpha-start)))

(defn shift [ch n]
  (if (= ch \-)
    \space
    (+ (mod (+ (- (byte ch) alpha-start) n) alpha-mod) alpha-start)))

(defn decrypt [room]
  (let [sector (:sector-id room)]
    (apply str (map #(char (shift % sector)) (:name room)))))

(defn is-northpole-object-storage? [room]
  (= "northpole object storage" (decrypt room)))

(defn -main []
  (with-open [rdr (reader "./data.txt")]
    (println (:sector-id (first (filter is-northpole-object-storage? 
                                        (map to-room (line-seq rdr))))))))
