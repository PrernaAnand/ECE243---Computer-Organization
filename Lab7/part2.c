#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

volatile int pixel_buffer_start;
    
void plot_pixel(int x, int y, short int line_color)
{
    *(short int *)(pixel_buffer_start + (y<<10) + (x<<1)) = line_color;
}

void swap(int *x, int *y)
{
    int temp = *x;
    *x = *y;
    *y = temp;
}

void draw_line(int x0, int y0, int x1, int y1, short  int line_color)
{
    bool is_steep = abs(y1 - y0) > abs(x1 - x0);

    if (is_steep) 
    {
        swap(&x0, &y0);
        swap(&x1, &y1);
    } 
    else if (x0 > x1) 
    {
        swap(&x0, &x1);
        swap(&y0, &y1);
    }

    int delta_x = x1 - x0;
    int delta_y = abs(y1 - y0);
    int error = -(delta_x / 2);
    int y = y0;
    int y_step = 0;

    if (y0 < y1) 
    {
        y_step = 1;
    } 
    else 
    {
        y_step = -1;
    }

    for (int i = x0; i != x1; i++)
    {
        if (is_steep) 
        {
            plot_pixel(y,i, line_color);
        } 
        else 
        {
            plot_pixel(i,y, line_color);
        }

        error = error + delta_y;
        if (error >= 0)
        {
            y = y + y_step;
            error = error - delta_x;
        }
    }         
}

void clear_screen()
{
    for (int row = 0; row < 320; row++) 
    {
        for (int col = 0; col < 240; col++) 
        {
            plot_pixel(row,col,0x0);
        }
    }
}

int main(void)
{
    volatile int * pixel_ctrl_ptr = (int *)0xFF203020;
    pixel_buffer_start = *pixel_ctrl_ptr;

    int x0 = 0;
    int y0 = 0;
    int x1 = 319;
    
    clear_screen();
    bool moving_down = true;

    while (1)
    {
        draw_line(x0, y0, x1, y0, 0x0);

        if (moving_down) 
        {
            if (y0==239) 
            {
                moving_down = false;
                y0 = 239;
            }
            else 
            {
                y0 = y0 + 1;
            }
        }
         
        else 
        {
            if (y0 == 0)
            {
                moving_down = true;
                y0 = 0;
            }
            else 
            {
                y0 = y0 - 1;
            }
        }
        
        draw_line(x0, y0, x1, y0, 0X001F);
        int count = 0;
        while (count != 36000)
            count++;
       
    }
}