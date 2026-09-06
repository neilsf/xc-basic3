' Tests LONG comparison operators in XC=BASIC
' MONITOR: m c000 c07f

DIM results(128) AS BYTE @ $C000
DIM loVal AS LONG, eqVal AS LONG, hiVal AS LONG
DIM minVal AS LONG, negVal AS LONG, zeroVal AS LONG, posVal AS LONG, maxVal AS LONG
DIM fastLo AS LONG FAST
DIM fastEq AS LONG FAST
DIM fastHi AS LONG FAST
DIM fastMin AS LONG FAST
DIM fastNeg AS LONG FAST
DIM fastZero AS LONG FAST
DIM fastPos AS LONG FAST
DIM fastMax AS LONG FAST
DIM vals(3) AS LONG
DIM bounds(5) AS LONG

MEMSET $C000, 128, 0

loVal = 70000 : eqVal = 123456 : hiVal = 765432
IF eqVal = eqVal THEN results(0) = 255 ELSE results(0) = 0
IF loVal = hiVal THEN results(1) = 255 ELSE results(1) = 0
IF loVal < hiVal THEN results(2) = 255 ELSE results(2) = 0
IF hiVal < loVal THEN results(3) = 255 ELSE results(3) = 0
IF hiVal > loVal THEN results(4) = 255 ELSE results(4) = 0
IF loVal > hiVal THEN results(5) = 255 ELSE results(5) = 0
IF eqVal <= eqVal THEN results(6) = 255 ELSE results(6) = 0
IF loVal <= hiVal THEN results(7) = 255 ELSE results(7) = 0
IF hiVal <= loVal THEN results(8) = 255 ELSE results(8) = 0
IF eqVal >= eqVal THEN results(9) = 255 ELSE results(9) = 0
IF hiVal >= loVal THEN results(10) = 255 ELSE results(10) = 0
IF loVal >= hiVal THEN results(11) = 255 ELSE results(11) = 0
IF loVal <> hiVal THEN results(12) = 255 ELSE results(12) = 0
IF eqVal <> eqVal THEN results(13) = 255 ELSE results(13) = 0

fastLo = 70000 : fastEq = 123456 : fastHi = 765432
IF fastEq = fastEq THEN results(14) = 255 ELSE results(14) = 0
IF fastLo = fastHi THEN results(15) = 255 ELSE results(15) = 0
IF fastLo < fastHi THEN results(16) = 255 ELSE results(16) = 0
IF fastHi < fastLo THEN results(17) = 255 ELSE results(17) = 0
IF fastHi > fastLo THEN results(18) = 255 ELSE results(18) = 0
IF fastLo > fastHi THEN results(19) = 255 ELSE results(19) = 0
IF fastEq <= fastEq THEN results(20) = 255 ELSE results(20) = 0
IF fastLo <= fastHi THEN results(21) = 255 ELSE results(21) = 0
IF fastHi <= fastLo THEN results(22) = 255 ELSE results(22) = 0
IF fastEq >= fastEq THEN results(23) = 255 ELSE results(23) = 0
IF fastHi >= fastLo THEN results(24) = 255 ELSE results(24) = 0
IF fastLo >= fastHi THEN results(25) = 255 ELSE results(25) = 0
IF fastLo <> fastHi THEN results(26) = 255 ELSE results(26) = 0
IF fastEq <> fastEq THEN results(27) = 255 ELSE results(27) = 0

vals(0) = 70000 : vals(1) = 123456 : vals(2) = 765432
IF vals(1) = vals(1) THEN results(28) = 255 ELSE results(28) = 0
IF vals(0) = vals(2) THEN results(29) = 255 ELSE results(29) = 0
IF vals(0) < vals(2) THEN results(30) = 255 ELSE results(30) = 0
IF vals(2) < vals(0) THEN results(31) = 255 ELSE results(31) = 0
IF vals(2) > vals(0) THEN results(32) = 255 ELSE results(32) = 0
IF vals(0) > vals(2) THEN results(33) = 255 ELSE results(33) = 0
IF vals(1) <= vals(1) THEN results(34) = 255 ELSE results(34) = 0
IF vals(0) <= vals(2) THEN results(35) = 255 ELSE results(35) = 0
IF vals(2) <= vals(0) THEN results(36) = 255 ELSE results(36) = 0
IF vals(1) >= vals(1) THEN results(37) = 255 ELSE results(37) = 0
IF vals(2) >= vals(0) THEN results(38) = 255 ELSE results(38) = 0
IF vals(0) >= vals(2) THEN results(39) = 255 ELSE results(39) = 0
IF vals(0) <> vals(2) THEN results(40) = 255 ELSE results(40) = 0
IF vals(1) <> vals(1) THEN results(41) = 255 ELSE results(41) = 0

IF 123456 = 123456 THEN results(42) = 255 ELSE results(42) = 0
IF 70000 = 765432 THEN results(43) = 255 ELSE results(43) = 0
IF 70000 < 765432 THEN results(44) = 255 ELSE results(44) = 0
IF 765432 < 70000 THEN results(45) = 255 ELSE results(45) = 0
IF 765432 > 70000 THEN results(46) = 255 ELSE results(46) = 0
IF 70000 > 765432 THEN results(47) = 255 ELSE results(47) = 0
IF 123456 <= 123456 THEN results(48) = 255 ELSE results(48) = 0
IF 70000 <= 765432 THEN results(49) = 255 ELSE results(49) = 0
IF 765432 <= 70000 THEN results(50) = 255 ELSE results(50) = 0
IF 123456 >= 123456 THEN results(51) = 255 ELSE results(51) = 0
IF 765432 >= 70000 THEN results(52) = 255 ELSE results(52) = 0
IF 70000 >= 765432 THEN results(53) = 255 ELSE results(53) = 0
IF 70000 <> 765432 THEN results(54) = 255 ELSE results(54) = 0
IF 123456 <> 123456 THEN results(55) = 255 ELSE results(55) = 0

IF loVal + 1 = 70001 THEN results(56) = 255 ELSE results(56) = 0
IF loVal + 1 = hiVal - 1 THEN results(57) = 255 ELSE results(57) = 0
IF loVal + 1 < hiVal - 1 THEN results(58) = 255 ELSE results(58) = 0
IF hiVal - 1 < loVal + 1 THEN results(59) = 255 ELSE results(59) = 0
IF hiVal - 1 > loVal + 1 THEN results(60) = 255 ELSE results(60) = 0
IF loVal + 1 > hiVal - 1 THEN results(61) = 255 ELSE results(61) = 0
IF eqVal + 1 <= eqVal + 1 THEN results(62) = 255 ELSE results(62) = 0
IF loVal + 1 <= hiVal - 1 THEN results(63) = 255 ELSE results(63) = 0
IF hiVal - 1 <= loVal + 1 THEN results(64) = 255 ELSE results(64) = 0
IF eqVal + 1 >= eqVal + 1 THEN results(65) = 255 ELSE results(65) = 0
IF hiVal - 1 >= loVal + 1 THEN results(66) = 255 ELSE results(66) = 0
IF loVal + 1 >= hiVal - 1 THEN results(67) = 255 ELSE results(67) = 0
IF loVal + 1 <> hiVal - 1 THEN results(68) = 255 ELSE results(68) = 0
IF eqVal + 1 <> eqVal + 1 THEN results(69) = 255 ELSE results(69) = 0

minVal = -8388608 : negVal = -1 : zeroVal = 0 : posVal = 1 : maxVal = 8388607
IF minVal < negVal THEN results(70) = 255 ELSE results(70) = 0
IF negVal < zeroVal THEN results(71) = 255 ELSE results(71) = 0
IF zeroVal < posVal THEN results(72) = 255 ELSE results(72) = 0
IF posVal < maxVal THEN results(73) = 255 ELSE results(73) = 0
IF maxVal < minVal THEN results(74) = 255 ELSE results(74) = 0
IF minVal > maxVal THEN results(75) = 255 ELSE results(75) = 0
IF maxVal > minVal THEN results(76) = 255 ELSE results(76) = 0
IF minVal <= minVal THEN results(77) = 255 ELSE results(77) = 0
IF maxVal >= maxVal THEN results(78) = 255 ELSE results(78) = 0
IF minVal <> maxVal THEN results(79) = 255 ELSE results(79) = 0
IF minVal = -8388608 THEN results(80) = 255 ELSE results(80) = 0
IF maxVal = 8388607 THEN results(81) = 255 ELSE results(81) = 0
IF -8388608 < 8388607 THEN results(82) = 255 ELSE results(82) = 0
IF 8388607 > -8388608 THEN results(83) = 255 ELSE results(83) = 0
IF -1 < 1 THEN results(84) = 255 ELSE results(84) = 0
IF 1 < -1 THEN results(85) = 255 ELSE results(85) = 0

fastMin = -8388608 : fastNeg = -1 : fastZero = 0 : fastPos = 1 : fastMax = 8388607
IF fastMin < fastNeg THEN results(86) = 255 ELSE results(86) = 0
IF fastNeg < fastZero THEN results(87) = 255 ELSE results(87) = 0
IF fastZero < fastPos THEN results(88) = 255 ELSE results(88) = 0
IF fastPos < fastMax THEN results(89) = 255 ELSE results(89) = 0
IF fastMax < fastMin THEN results(90) = 255 ELSE results(90) = 0
IF fastMax > fastMin THEN results(91) = 255 ELSE results(91) = 0
IF fastMin <= fastMin THEN results(92) = 255 ELSE results(92) = 0
IF fastMax >= fastMax THEN results(93) = 255 ELSE results(93) = 0
IF fastMin <> fastMax THEN results(94) = 255 ELSE results(94) = 0
IF fastMin = fastMax THEN results(95) = 255 ELSE results(95) = 0

bounds(0) = -8388608 : bounds(1) = -1 : bounds(2) = 0 : bounds(3) = 1 : bounds(4) = 8388607
IF bounds(0) < bounds(1) THEN results(96) = 255 ELSE results(96) = 0
IF bounds(1) < bounds(2) THEN results(97) = 255 ELSE results(97) = 0
IF bounds(2) < bounds(3) THEN results(98) = 255 ELSE results(98) = 0
IF bounds(3) < bounds(4) THEN results(99) = 255 ELSE results(99) = 0
IF bounds(4) < bounds(0) THEN results(100) = 255 ELSE results(100) = 0
IF bounds(4) > bounds(0) THEN results(101) = 255 ELSE results(101) = 0
IF bounds(0) <= bounds(0) THEN results(102) = 255 ELSE results(102) = 0
IF bounds(4) >= bounds(4) THEN results(103) = 255 ELSE results(103) = 0
IF bounds(0) <> bounds(4) THEN results(104) = 255 ELSE results(104) = 0
IF bounds(2) = 0 THEN results(105) = 255 ELSE results(105) = 0

IF minVal + 1 < zeroVal - 1 THEN results(106) = 255 ELSE results(106) = 0
IF maxVal - 1 > zeroVal + 1 THEN results(107) = 255 ELSE results(107) = 0
IF negVal + 1 = zeroVal THEN results(108) = 255 ELSE results(108) = 0
IF posVal - 1 = zeroVal THEN results(109) = 255 ELSE results(109) = 0
IF minVal + 8388607 = negVal THEN results(110) = 255 ELSE results(110) = 0
IF maxVal - 8388606 = posVal THEN results(111) = 255 ELSE results(111) = 0
IF minVal + 10 > maxVal - 10 THEN results(112) = 255 ELSE results(112) = 0
IF maxVal - 10 < minVal + 10 THEN results(113) = 255 ELSE results(113) = 0