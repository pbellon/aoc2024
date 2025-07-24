# How to generate all combination?

```
List of numbers:
1 2 3

All combination
1 + 2 + 3
1 * 2 + 3
1 * 2 * 3
1 + 2 * 3


Expressed as binary
a b c d

+ + +    // 000
+ + *    // 001
+ * +    // 010
+ * *    // 011
* + +    // 100
* + *    // 101
* * +    // 110
* * *    // 111
```

```
const nb_bits = nbs.length - 1;
const max = pow(2, nb_bits);
for (i = 0; i < max; i++) {
    for (j = 0; j < nb_bit; j++) {
        // how to get value of bit at `j` pos from left to right
    }

}
```