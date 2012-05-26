/* Arena allocator for Hammer.
 * Copyright (C) 2012  Meredith L. Patterson, Dan "TQ" Hirsch
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation, version 2.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#ifndef HAMMER_ALLOCATOR__H__
#define HAMMER_ALLOCATOR__H__
#include <sys/types.h>

typedef struct HArena_ HArena ; // hidden implementation

HArena *new_arena(size_t block_size); // pass 0 for default...
void* arena_malloc(HArena *arena, size_t count) __attribute__(( malloc, alloc_size(2) ));
void delete_arena(HArena *arena);

typedef struct {
  size_t used;
  size_t wasted;
} HArenaStats;

void allocator_stats(HArena *arena, HArenaStats *stats);


#endif // #ifndef LIB_ALLOCATOR__H__