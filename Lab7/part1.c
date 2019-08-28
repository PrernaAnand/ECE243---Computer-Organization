#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

volatile int pixel_buffer_start;    // pixel buffer

void swap(int *x, int *y)
{
    int temp = *x;
    *x = *y;
    *y = temp;
}

void plot_pixel(int x, int y, short int line_color)
{
    *(short int *)(pixel_buffer_start + (y<<10) + (x<<1)) = line_color;
}

void draw_line(int x0, int y0, int x1, int y1, short  int line_color)
{
    bool is_steep = abs(y1 - y0) > abs(x1 - x0);

    if (is_steep) {
        swap(&x0, &y0);
        swap(&x1, &y1);
    } else if (x0 > x1) {
        swap(&x0, &x1);
        swap(&y0, &y1);
    }

    int delta_x = x1 - x0;
    int delta_y = abs(y1 - y0);
    int error = -(delta_x / 2);
    int y = y0;
    int y_step = 0;

    if (y0 < y1) {
        y_step = 1;
    } else {
        y_step = -1;
    }

    for (int i= x0; i != x1; i++)
    {
        if (is_steep) {
            plot_pixel(y,i, line_color);
        } else {
            plot_pixel(i,y, line_color);
        }
        
        error = error + delta_y;
        if (error >= 0) {
            y = y + y_step;
            error = error - delta_x;
        }
    }         
}

void clear_screen()
{
    for (int row = 0; row < 320; row++) {
        for (int col = 0; col < 240; col++) {
            *(short int *)(pixel_buffer_start + (col<<10) + (row<<1)) = 0xFFFFFFFF;
        }
    }
}

int main(void)
{
    volatile int * pixel_ctrl_ptr = (int *)0xFF203020;

    pixel_buffer_start = *pixel_ctrl_ptr;
    
    clear_screen();
    draw_line(0,0,150,150, 0X001F);
    draw_line(150,150,319,0,0x07E0);
    draw_line(0,239,319,239,0xF800);
    draw_line(319,0,0,239,0xF81F);
    
    return 0;
}