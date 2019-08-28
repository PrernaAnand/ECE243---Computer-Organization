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

    for (int i=x0; i != x1; i++)
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

void wait_for_vsync()
{
    volatile int * pixel_ctrl_ptr = (int *)0xFF203020;
    register int status;
    
    *pixel_ctrl_ptr = 1;
    status = *(pixel_ctrl_ptr + 3);
    
    while ( (status & 0x01) != 0)
    {
        status = *(pixel_ctrl_ptr + 3);
    }
}

void draw(int x, int y, short int colour)
{
    for(int i = 0; i < 3; i++) 
    {
        for(int j = 0; j < 3; j++)
        {
            plot_pixel(x + i, y + j, colour);
        }
    }    
}

int main(void)
{
    volatile int * pixel_ctrl_ptr = (int *)0xFF203020;
    *(pixel_ctrl_ptr + 1) = 0xC8000000; 
    wait_for_vsync();

    pixel_buffer_start = *pixel_ctrl_ptr;
    clear_screen();
    
    *(pixel_ctrl_ptr + 1) = 0xC0000000;
    pixel_buffer_start = *(pixel_ctrl_ptr + 1);  //back buffer

    int x[8]; 
    int y[8]; 
    short int color_rand[8]; 
    int color[10] = {0x001F,0x07E0,0xF800,0xF81F,0xBf3eff,0x07E0,0xF81F,0x07E0,0xF81F,0xF81F};
    bool moving_down[8] = {true, true, true, true, true, true, true, true};
    bool moving_left[8] = {true, true, true, true, true, true, true, true};
    
    srand(0);
    for(int i = 0; i < 8; i++)
    {
        x[i] = rand()%319 + 1;
        y[i] = rand()%239 + 1;
        color_rand[i] = color[rand()%10];
    }
       
    while (1)
    {       
        clear_screen();
        
        for(int k = 0; k < 7; k++)
        {
          draw(x[k], y[k], color_rand[k]);
          draw_line(x[k], y[k], x[k+1], y[k+1], color_rand[k]);
        }
        
        for(int i = 0; i < 7; i++)
        {
            if (moving_down[i]) 
            {
                if (y[i]>=236) 
                {
                    moving_down[i] = false;
                    y[i] = 236;
                }
                else 
                {
                    y[i] = y[i] + 1;
                }
            }

            else 
            {
                if (y[i] <= 0)
                {
                    moving_down[i] = true;
                    y[i] = 0;
                }
                else 
                {
                    y[i] = y[i] - 1;
                }
            }
            
            if (moving_left[i]) 
            {
                if (x[i]<=0) 
                {
                    moving_left[i] = false;
                    x[i] = 0;
                }
                else 
                {
                    x[i] = x[i] - 1;
                }
            }

            else 
            {
                if (x[i] >= 316)
                {
                    moving_left[i] = true;
                    x[i] = 316;
                }
                else 
                {
                    x[i] = x[i] + 1;
                }
            }

        }
        
        wait_for_vsync();
        pixel_buffer_start = *(pixel_ctrl_ptr + 1);
    }
    
    return 0;
}