/*
 * @Date: 2023-06-03 23:31:48
 * @LastEditors: 974782852@qq.com
 * @LastEditTime: 2023-06-04 13:37:33
 * @FilePath: \iotop_test\src\main.c
 */
/* SPDX-License-Identifier: GPL-2.0-or-later

Copyright (C) 2014  Vyacheslav Trushkin
Copyright (C) 2020-2023  Boian Bonev

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

*/

#include "iotop.h"

#include <pwd.h>
#include <ctype.h>
#include <getopt.h>
#include <stdio.h>
#include <locale.h>
#include <signal.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>

config_t config;
params_t params;

int maxpidlen=5;

view_init v_init_cb=view_batch_init;
view_fini v_fini_cb=view_batch_fini;
view_loop v_loop_cb=view_batch_loop;

int main(int argc,char *argv[]) {
	memset(&config,0,sizeof(config));
	config.f.sort_by=SORT_BY_GRAPH;
	config.f.sort_order=SORT_DESC;
	config.f.base=1024; // use non-SI units by default
	config.f.threshold=2; // default threshold is 2*base
	config.f.unicode=1; // default is unicode
	config.f.fullcmdline = 1; //显示完全指令
	
	nl_init();
	v_init_cb();
	v_loop_cb();
	v_fini_cb();
	nl_fini();
	return 0;
}
