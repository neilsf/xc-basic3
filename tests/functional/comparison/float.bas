' Tests FLOAT comparison operators in XC=BASIC
' MONITOR: m c000 c04f

DIM results(80) AS BYTE @ $C000
DIM loVal AS FLOAT, eqVal AS FLOAT, hiVal AS FLOAT
DIM fastLo AS FLOAT FAST
DIM fastEq AS FLOAT FAST
DIM fastHi AS FLOAT FAST
DIM vals(3) AS FLOAT

MEMSET $C000, 80, 0

loVal = -12.5 : eqVal = 3.25 : hiVal = 456.75
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

fastLo = -12.5 : fastEq = 3.25 : fastHi = 456.75
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

vals(0) = -12.5 : vals(1) = 3.25 : vals(2) = 456.75
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

IF 3.25 = 3.25 THEN results(42) = 255 ELSE results(42) = 0
IF -12.5 = 456.75 THEN results(43) = 255 ELSE results(43) = 0
IF -12.5 < 456.75 THEN results(44) = 255 ELSE results(44) = 0
IF 456.75 < -12.5 THEN results(45) = 255 ELSE results(45) = 0
IF 456.75 > -12.5 THEN results(46) = 255 ELSE results(46) = 0
IF -12.5 > 456.75 THEN results(47) = 255 ELSE results(47) = 0
IF 3.25 <= 3.25 THEN results(48) = 255 ELSE results(48) = 0
IF -12.5 <= 456.75 THEN results(49) = 255 ELSE results(49) = 0
IF 456.75 <= -12.5 THEN results(50) = 255 ELSE results(50) = 0
IF 3.25 >= 3.25 THEN results(51) = 255 ELSE results(51) = 0
IF 456.75 >= -12.5 THEN results(52) = 255 ELSE results(52) = 0
IF -12.5 >= 456.75 THEN results(53) = 255 ELSE results(53) = 0
IF -12.5 <> 456.75 THEN results(54) = 255 ELSE results(54) = 0
IF 3.25 <> 3.25 THEN results(55) = 255 ELSE results(55) = 0

IF loVal + 0.5 = -12.0 THEN results(56) = 255 ELSE results(56) = 0
IF loVal + 0.5 = hiVal - 0.5 THEN results(57) = 255 ELSE results(57) = 0
IF loVal + 0.5 < hiVal - 0.5 THEN results(58) = 255 ELSE results(58) = 0
IF hiVal - 0.5 < loVal + 0.5 THEN results(59) = 255 ELSE results(59) = 0
IF hiVal - 0.5 > loVal + 0.5 THEN results(60) = 255 ELSE results(60) = 0
IF loVal + 0.5 > hiVal - 0.5 THEN results(61) = 255 ELSE results(61) = 0
IF eqVal + 0.5 <= eqVal + 0.5 THEN results(62) = 255 ELSE results(62) = 0
IF loVal + 0.5 <= hiVal - 0.5 THEN results(63) = 255 ELSE results(63) = 0
IF hiVal - 0.5 <= loVal + 0.5 THEN results(64) = 255 ELSE results(64) = 0
IF eqVal + 0.5 >= eqVal + 0.5 THEN results(65) = 255 ELSE results(65) = 0
IF hiVal - 0.5 >= loVal + 0.5 THEN results(66) = 255 ELSE results(66) = 0
IF loVal + 0.5 >= hiVal - 0.5 THEN results(67) = 255 ELSE results(67) = 0
IF loVal + 0.5 <> hiVal - 0.5 THEN results(68) = 255 ELSE results(68) = 0
IF eqVal + 0.5 <> eqVal + 0.5 THEN results(69) = 255 ELSE results(69) = 0