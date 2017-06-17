# Version history for the _Harmonex_ project

## <a name="v0.5.0"></a>v0.5.0, Sat 6/17/2017

* Implement _Interval.semitones/1_ and _.simplify/1_
* Rename _Pitch.alteration/1_ to _.accidental/1_
* Rename *Pitch.bare_name/1* to *.natural_name/1*
* Rename *Pitch.full_name/1* to _.name_
* Enhance documentation by introducing more granular types and better documenting
  existing ones

## <a name="v0.4.0"></a>v0.4.0, Mon 5/22/2017

* Extract _Interval_ and reimplement *Pitch.interval_diatonic/2* as
  *Interval.between_pitches/2* and _Pitch.interval/2_

## <a name="v0.3.0"></a>v0.3.0, Sun 5/14/2017

* Implement error handling in all _Pitch_ functions

## <a name="v0.2.0"></a>v0.2.0, Tue 5/09/2017

* Add _Pitch.enharmonics/1_ and add `:doubly_diminished` and `:doubly_augmented`
  to the _Pitch.quality_ type

## <a name="v0.1.0"></a>v0.1.0, Tue 5/09/2017

(First release)
