#include <cstdio>
#include <cstdlib>
#include <string>
#include <stdint.h>

// ======================================================
// ======================================================
struct MandelbrotParams {

  //! image width in pixel
  unsigned int NX;

  //! image hieght in pixel
  unsigned int NY;

  //! maximun number of iterations in used mandelbrot compute
  unsigned int MAX_ITERS;

  //! maximum number of colors, for scaling the number of iterations
  unsigned int MAX_COLOR;

  //! global domain, lower left corner x coordinate
  double xmin;

  //! global domain, lower left corner y coordinate
  double ymin;

  //! global domain, upper right corner x coordinate
  double xmax;

  //! global domain, upper right corner x coordinate
  double ymax;

  //! distance between two grid points
  double dx;

  //! distance between two grid points
  double dy;

  //! offset to local domain - x coordinate
  int imin;

  //! offset to local domain - y coordinate
  int jmin;

  //! number of pixels in local sub-domain along x axis - identical to NX in sequential
  int delta_i;

  //! number of pixels in local sub-domain along y axis - identical to NY in sequential
  int delta_j;

  //! default constructor - local subdomain is equal to the entire domain
  MandelbrotParams(int default_size)
      : NX(default_size), NY(default_size), MAX_ITERS(4000), MAX_COLOR(255),
        xmin(-1.7), ymin(-1.2), xmax(.5), ymax(1.2), dx(0.0), dy(0.0), imin(0),
        jmin(0), delta_i(NX), delta_j(NY)

  {
    dx = (xmax - xmin) / NX;
    dy = (ymax - ymin) / NY;
  }

  MandelbrotParams(int default_size, int imin_, int jmin_, int delta_i_,
                   int delta_j_)
      : MandelbrotParams(default_size) {
    imin = imin_;
    jmin = jmin_;
    delta_i = delta_i_;
    delta_j = delta_j_;
  }

}; // struct MandelbrotParams

// ======================================================
// ======================================================
class MandelbrotSet {

public:
  MandelbrotSet(MandelbrotParams params) : m_params(params) {
    data = new uint8_t[m_params.delta_i * m_params.delta_j];
  }

  ~MandelbrotSet() { delete[] data; }

  void compute() {
    auto &imin = m_params.imin;
    auto &jmin = m_params.jmin;
    auto &delta_i = m_params.delta_i;
    auto &delta_j = m_params.delta_j;
    auto &NX = m_params.NX;

    for (int j = jmin; j < jmin + delta_j; ++j)
      for (int i = imin; i < imin + delta_i; ++i) {
        // local coordinates
        int il = i - imin;
        int jl = j - jmin;
        data[il + NX * jl] = compute_pixel(i, j);
      }
  }

  uint8_t *data;

private:
  MandelbrotParams m_params;

  uint8_t compute_pixel(int Px, int Py) const {

    auto &dx = m_params.dx;
    auto &dy = m_params.dy;
    auto &xmin = m_params.xmin;
    auto &ymin = m_params.ymin;

    auto &MAX_ITERS = m_params.MAX_ITERS;
    auto &MAX_COLOR = m_params.MAX_COLOR;

    float x0 = xmin + Px * dx;
    float y0 = ymin + Py * dy;
    float x = 0.0;
    float y = 0.0;
    int i = 0;

    for (i = 0; x * x + y * y < 4.0 and i < MAX_ITERS; i++) {
      float xtemp = x * x - y * y + x0;
      y = 2 * x * y + y0;
      x = xtemp;
    }
    return static_cast<uint8_t>(MAX_COLOR * i / MAX_ITERS);
  }

}; // class MandelbrotSet

// ======================================================
// ======================================================
void write_screen(uint8_t *data, const MandelbrotParams &params) {
  // print aesthetically, dont read this part
  int xmax = 80;
  int ymax = 60;
  for (int y = 0; y < ymax; y++) {
    auto j = y * params.NY / ymax;
    if (j >= params.jmin and j < params.jmin + params.delta_j) {
      printf("\n");
      for (int x = 0; x < xmax; x++) {
        auto i = x * params.NX / xmax;

        // local coordinates
        int il = i - params.imin;
        int jl = j - params.jmin;

        int val = data[il + params.NX * jl];

        if (val == 200)
          printf("&");
        else if (val == 42)
          printf("X");
        else if (val > 64)
          printf("#");
        else if (val > 32)
          printf(":");
        else if (val > 8)
          printf(".");
        else
          printf(" ");
      }
    }
  }

  printf("\n");

} // write_screen

// ======================================================
// ======================================================
void write_ppm(uint8_t *data, const std::string &filename,
               const MandelbrotParams &params) {
  auto &NX = params.NX;
  auto &NY = params.NY;

  FILE *myfile = fopen(filename.c_str(), "w");

  fprintf(myfile, "P6 %d %d 255\n", NX, NY);
  for (unsigned int i = 0; i < NX; ++i) {
    for (unsigned int j = 0; j < NY; ++j) {

      uint8_t pix;
      // create an arbitrary RBG code mapping values taken by imageHost
      pix = data[i + NX * j] % 4 * 64;
      fwrite(&pix, 1, 1, myfile);
      pix = data[i + NX * j] % 8 * 32;
      fwrite(&pix, 1, 1, myfile);
      pix = data[i + NX * j] % 16 * 16;
      fwrite(&pix, 1, 1, myfile);
    }
  }

  fclose(myfile);

} // write_ppm

// ======================================================
// ======================================================
int main(int argc, char *argv[])
{

  const int size = 512;

  MandelbrotParams params = MandelbrotParams(
    size, 0, 0, size, size);
  MandelbrotSet mset = MandelbrotSet(params);
  mset.compute();

  // write_screen(mset.data, params);

  // write results in a ppm image
  uint8_t *image;

  auto &NX = params.NX;
  auto &NY = params.NY;
  auto &imin = params.imin;
  auto &jmin = params.jmin;
  auto &delta_i = params.delta_i;
  auto &delta_j = params.delta_j;

  image = new uint8_t[NX * NY];

  // copy our own piece into image
  for (int j = jmin; j < jmin + delta_j; ++j) {
    for (int i = imin; i < imin + delta_i; ++i) {
      // local coordinates
      int il = i - imin;
      int jl = j - jmin;
      image[i + NX * j] = mset.data[il + NX * jl];
    }
  }

  // finaly write complete image
  write_ppm(image, "mandelbrot.ppm", params);

  delete[] image;

  return EXIT_SUCCESS;
}
