#include <cstdio>
#include "cpu.h"

namespace StreamCompaction {
namespace CPU {

double last_runtime;

/**
 * CPU scan (prefix sum).
 */
void scan(int n, int *odata, const int *idata) {
    double t1 = clock();

    int t = 0;
    for (int i = 0; i < n; i++) {
      odata[i] = t;
      t += idata[i];
    }

    double t2 = clock();
    last_runtime = 1.0E6*(t2-t1)/CLOCKS_PER_SEC;
}

/**
 * CPU stream compaction without using the scan function.
 *
 * @returns the number of elements remaining after compaction.
 */
int compactWithoutScan(int n, int *odata, const int *idata) {
    double t1 = clock();

    int oIdx = 0;
    for (int i = 0; i < n; i++) {
      if (idata[i] != 0) {
        odata[oIdx] = idata[i];
        oIdx++;
      }
    }

    double t2 = clock();
    last_runtime = 1.0E6*(t2-t1)/CLOCKS_PER_SEC;
    return oIdx;
}

/**
 * CPU stream compaction using scan and scatter, like the parallel version.
 *
 * @returns the number of elements remaining after compaction.
 */
int compactWithScan(int n, int *odata, const int *idata) {
    double t1 = clock();

    int *keep = new int[n];
    for (int i = 0; i < n; i++) {
      keep[i] = (idata[i] != 0) ? 1 : 0;
    }

    int *keepScan = new int[n];
    int nKeep = 0;
    scan(n, keepScan, keep);
    for (int i = 0; i < n; i++) {
      if (!keep[i])
        continue;

      nKeep++;
      odata[keepScan[i]] = idata[i];
    }

    double t2 = clock();
    last_runtime = 1.0E6*(t2-t1)/CLOCKS_PER_SEC;

    delete keepScan;
    delete keep;
    return nKeep;
}

}
}
